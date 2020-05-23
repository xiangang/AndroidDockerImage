# Android持续集成Docker镜像，基于ubuntu镜像，使用网易源加速
FROM hub.c.163.com/public/ubuntu:16.04-tools 
# 维护者信息
MAINTAINER https://github.com/xiangang  

#  ------------------------------------------------------
#  --- 安装需要的工具

# 添加32位运行库支持
RUN dpkg --add-architecture i386
# 更新apt-get
RUN apt-get update -qq
# DEBIAN_FRONTEND环境变量设置为noninteractive可以直接运行命令
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openjdk-8-jdk libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386 apt-utils net-tools zip unzip git \ 
    && apt-get clean
	

#  ------------------------------------------------------
#  --- 创建AndroidSDK目录，下载Android命令行工具，并配置AndroidSDK环境变量$ANDROID_HOME

# 创建目录
RUN mkdir -p /opt/android-sdk-linux

# 设置环境变量
ENV ANDROID_HOME /opt/android-sdk-linux

# 下载Android命令行工具解压放到android-sdk-linux目录下
RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm android-sdk-tools.zip
	
# $ANDROID_HOME添加到PATH中
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

#  ------------------------------------------------------
#  --- 安装 Android SDK 和 其他的 Build Packages

# SDKManager的使用请参考官网介绍：https://developer.android.google.cn/studio/command-line/sdkmanager
# 使用代理设置会报错FileNotFoundException，待解决： --no_https --proxy=http --proxy_host=mirrors.neusoft.edu.cn --proxy_port=80
# 列出已安装和可用的软件包
RUN sdkmanager --sdk_root=${ANDROID_HOME} --list --verbose

# 需要先Accept licenses
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses

# 创建/root/.android/repositories.cfg
RUN touch /root/.android/repositories.cfg

# 通过SDKManager安装tools，platform-tools
RUN sdkmanager --sdk_root=${ANDROID_HOME} "tools" "platform-tools" 

# 下载安装SDK
# 更新所有已安装的软件包
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --update --channel=3

# 必须按降序排列，下载安装指定版本的platforms、build-tools、extras等
# 这里罗列的较多的版本，请根据实际需要进行删减
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} \
    "platforms;android-29" \
    "platforms;android-28" \
    "platforms;android-27" \
    "platforms;android-26" \
    "platforms;android-25" \
    "platforms;android-24" \
    "platforms;android-23" \
    "platforms;android-22" \
    "platforms;android-21" \
    "platforms;android-19" \
    "build-tools;29.0.3" \
    "build-tools;29.0.2" \
    "build-tools;29.0.1" \
    "build-tools;29.0.0" \
    "build-tools;28.0.3" \
    "build-tools;28.0.2" \
    "build-tools;28.0.1" \
    "build-tools;28.0.0" \
    "build-tools;27.0.3" \
    "build-tools;27.0.2" \
    "build-tools;27.0.1" \
    "build-tools;27.0.0" \
    "build-tools;26.0.2" \
    "build-tools;26.0.1" \
    "build-tools;25.0.3" \
    "build-tools;24.0.3" \
    "build-tools;23.0.3" \
    "build-tools;22.0.1" \
    "build-tools;21.1.2" \
    "build-tools;19.1.0" 
	
	
#  ------------------------------------------------------
#  --- 安装 Gradle 

# Gradle官网：https://services.gradle.org/distributions/
ENV GRADLE_VERSION=5.4.1
ENV PATH=$PATH:"/opt/gradle/gradle-${GRADLE_VERSION}/bin/"
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp \
    && unzip -d /opt/gradle /tmp/gradle-*.zip \
    && chmod +775 /opt/gradle \
    && gradle --version \
    && rm -rf /tmp/gradle*
	
#  ------------------------------------------------------
#  --- 收尾工作

# 删除已安装的安装包
RUN apt-get clean
