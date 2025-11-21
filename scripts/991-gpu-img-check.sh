#!/bin/bash

# DigitalOcean Marketplace Image Validation Tool
# © 2025 DigitalOcean LLC.
# This code is licensed under Apache 2.0 license (see LICENSE.md for details)

VERSION="v. 1.0.0"
RUNDATE=$( date )

components=""
components_count=0

# Script should be run with SUDO
if [ "$EUID" -ne 0 ]
  then echo "[Error] - This script must be run with sudo or as the root user."
  exit 1
fi

function add_component() {
    if [ -z "$components" ] ; then
        components="$1"
        components_count=1
        return
    fi
    components="${components},$1"
    ((components_count++))
}

function checkNvidia() {
    if command -v nvidia-smi > /dev/null 2>&1 ; then
        driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -n 1)
        hardware=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n 1)
        echo -en "\e[32m[PASS]\e[0m NVIDIA GPU hardware detected: ${hardware}.\n"
        if nvidia-smi -L 2>/dev/null | grep -q "GPU" ; then
            echo -en "\e[32m[PASS]\e[0m Driver can see hardware.\n"
            ((PASS++))
            add_component "hardware"
        else
            echo -en "\e[93m[WARN]\e[0m Driver installed but can't detect hardware (build environment).\n"
            ((WARN++))
        fi

        if [ -z "$driver_version" ] ; then
            echo -en "\e[93m[WARN]\e[0m Unable to determine NVIDIA driver version.\n"
            ((WARN++))
        else
            major_ver=$(echo "$driver_version" | cut -d. -f1)
            if [[ $major_ver -lt 470 ]] ; then # Example threshold
                echo -en "\e[93m[WARN]\e[0m Flag potentially outdated NVIDIA driver.\n"
                ((WARN++))
            else
                echo -en "\e[32m[PASS]\e[0m Not outdated NVIDIA version: ${driver_version}.\n"
                ((PASS++))
                add_component "driver"
            fi
        fi
        return 0
    fi
    echo -en "\e[93m[WARN]\e[0m Can't find NVIDIA driver version.\n"
    ((WARN++))
}

function checkAMD() {
    if command -v rocm-smi>/dev/null 2>&1 ; then
        # Get ROCm version
        rocm_version=$(rocm-smi --version 2>/dev/null | grep -E "ROCM-SMI version|ROCm" | awk '{print $NF}')
        hardware=$(rocm-smi --showproductname 2>/dev/null | grep "GPU" | awk -F: '{print $2}' | xargs)
        echo -en "\e[32m[PASS]\e[0m AMD GPU hardware detected: ${hardware}.\n"
        # Check hardware detection
        if rocm-smi --showallinfo 2>/dev/null | grep -Eq "GPU ID|GPU\["; then
            # Driver can see hardware
            add_component "hardware"
            echo -en "\e[32m[PASS]\e[0m AMD driver can see hardware.\n"
            ((PASS++))
        else
            # Driver installed but can't detect hardware (build environment)
            echo -en "\e[93m[WARN]\e[0m AMD driver installed but can't detect hardware (build environment).\n"
            ((WARN++))
        fi

        # Version check
        rocm_major=$(echo $rocm_version | cut -d. -f1)
        if [ -z "$rocm_major" ] ; then
            echo -en "\e[93m[WARN]\e[0m Unable to determine AMD driver version.\n"
            ((WARN++))
        else
            if [[ $rocm_major -lt 5 ]] ; then
                # Flag potentially outdated driver
                echo -en "\e[93m[WARN]\e[0m Flag potentially outdated AMD driver version: ${rocm_version} .\n"
                ((WARN++))
            else
                echo -en "\e[32m[PASS]\e[0m Not outdated AMD driver version: ${rocm_version}.\n"
                ((PASS++))
            fi
        fi
        return 0
    fi
    echo -en "\e[93m[WARN]\e[0m Can't find AMD driver version.\n"
    ((WARN++))
}

function checkNvidiaToolKit() {
    if command -v nvcc > /dev/null 2>&1; then
        add_component "cuda"
        echo -en "\e[32m[PASS]\e[0m NVIDIA CUDA Toolkit is installed.\n"
        ((PASS++))
    else
        if [ -d /usr/local/cuda ]; then
            if [ -f /usr/local/cuda/version.txt ]; then
                cuda_version = $(cat /usr/local/cuda/version.txt)
                echo -en "\e[32m[PASS]\e[0m NVIDIA CUDA Toolkit is installed. Version: ${cuda_version}\n"
                ((PASS++))
                add_component "cuda"
                return 0
            fi
        fi
        echo -en "\e[41m[FAIL]\e[0m NVIDIA CUDA Toolkit is not installed.\n"
        ((FAIL++))
    fi
}

function checkAMDToolKit() {
    if dpkg -l | grep -q "rocm-dev"; then
        add_component "hip"
        echo -en "\e[32m[PASS]\e[0m AMD ROCm Development Toolkit is installed.\n"
        ((PASS++))
    else
        if [ -d /opt/rocm/hip ]; then
            add_component "hip"
            echo -en "\e[32m[PASS]\e[0m AMD ROCm Development Toolkit is installed, ROCm HIP directory found.\n"
            ((PASS++))
        else
            echo -en "\e[41m[FAIL]\e[0m AMD ROCm Development Toolkit is not installed.\n"
            ((FAIL++))
        fi
    fi
}

function checkNvidiaRuntimeCfg() {
   # Check Docker integration if Docker is installed
   if command -v docker>/dev/null 2>&1; then
       if docker info 2>/dev/null | grep -q "nvidia"; then
           # Docker has NVIDIA runtime configured
            echo -en "\e[32m[PASS]\e[0m There is docker runtime configuration for NVIDIA GPU.\n"
            ((PASS++))
            add_component "docker"
            return 0
       fi
        echo -en "\e[93m[WARN]\e[0m Docker is installed, but NVIDIA GPU runtime is not detected\nConsider configuring Docker for NVIDIA GPU support.\n"
        ((WARN++))
        return 0
   fi

    echo -en "\e[93m[WARN]\e[0m Docker is not installed\n"
    ((WARN++))
}

function checkAMDRuntimeCfg() {
     if command -v docker >/dev/null 2>&1 && [ -f /etc/docker/daemon.json ]; then
       if grep -q "amd\|rocm" /etc/docker/daemon.json 2>/dev/null; then
            echo -en "\e[32m[PASS]\e[0m There is docker runtime configuration for AMD GPU.\n"
            ((PASS++))
            add_component "docker"
            return 0
       fi
       echo -en "\e[93m[WARN]\e[0m Docker is installed but AMD GPU runtime not detected\mConsider configuring Docker for AMD GPU support.\n"
       ((WARN++))
       return 0
   fi

    echo -en "\e[93m[WARN]\e[0m Docker is not installed\n"
    ((WARN++))
}

function checkNvidiaBootAndSecurity() {
    if grep -q "nvidia" /etc/modules 2>/dev/null || ls /etc/modules-load.d/*nvidia* >/dev/null 2>&1; then
        echo -en "\e[32m[PASS]\e[0m NVIDIA driver loads on boot.\n"
        ((PASS++))
        add_component "boot"
    else
        echo -en "\e[41m[FAIL]\e[0m NVIDIA driver not configured to load at boot.\n"
        ((FAIL++))
    fi

    if command -v nvidia-smi >/dev/null 2>&1 && !(nvidia-smi -L 2>/dev/null | grep -q "GPU") ; then
        echo -en "\e[93m[WARN]\e[0m NVIDIA drivers installed but no GPU hardware detected. This is expected in build environments.\n"
        ((WARN++))
    fi
    echo -en "\e[34m[INFO]\e[0m Visit https://www.nvidia.com/en-us/security/ to verify if driver version is not outdated\n"
}

function checkAMDBootAndSecurity() {
    # Check if AMD GPU drivers are configured to load at boot
    if ls /etc/modules-load.d/*amd* >/dev/null 2>&1 || ls /etc/modules-load.d/*gpu* >/dev/null 2>&1; then
        echo -en "\e[32m[PASS]\e[0m AMD driver is configured to load at boot.\n"
        ((PASS++))
        add_component "boot"
    elif grep -q amdgpu /proc/modules || [ -d /sys/module/amdgpu ]; then
        echo -en "\e[32m[PASS]\e[0m AMD driver is configured to load at boot.\n"
        ((PASS++))
        add_component "boot"
    else
        echo -en "\e[41m[FAIL]\e[0m AMD driver is not configured to load at boot.\n"
        ((FAIL++))
    fi

    # Provide a security info message
    echo -en "\e[34m[INFO]\e[0m Visit https://www.amd.com/en/corporate/product-security to verify if driver version is not outdated.\n"
}

driver="NOT_FOUND"
if lspci -d "10de:" | grep -i "nvidia\|3d controller\|vga" > /dev/null 2>&1; then
    echo "NVIDIA-related hardware detected"
    driver="NVIDIA"
elif  lspci | grep -i "amd\|advanced micro devices\|radeon" | grep -i "graphics\|3d\|display\|vga"; then
    echo "NVIDIA-related hardware detected"
    driver="AMD"
elif [ -e /dev/nvidia0 ] || [ -d /proc/driver/nvidia ]; then
    driver="NVIDIA"
    echo "NVIDIA hardware likely present"
elif grep -q amdgpu /proc/modules || [ -d /sys/module/amdgpu ]; then
    driver="AMD"
    echo "AMD hardware likely present"
fi

if [ "$driver" == "NVIDIA" ]; then
    echo "==== GPU-specific checks ===="
    checkNvidia
    checkNvidiaToolKit
    checkNvidiaRuntimeCfg
    checkNvidiaBootAndSecurity
    echo "==== GPU Check Summary ===="
    echo -en "\e[34m[INFO]\e[0m Found ${components_count} AMD GPU components: ${components}\n"
elif [ "$driver" == "AMD" ]; then
    echo "==== GPU-specific checks ===="
    checkAMD
    checkAMDToolKit
    checkAMDRuntimeCfg
    checkAMDBootAndSecurity
    echo "==== GPU Check Summary ===="
    echo -en "\e[34m[INFO]\e[0m Found ${components_count} AMD GPU components: ${components}\n"
else
    echo -en "\e[93m[INFO]\e[0m No supported GPU hardware detected.\n"
fi
