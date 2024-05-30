if (NOT QNN_ARCH_ABI)
    if(MSVC)
        string(TOLOWER ${CMAKE_GENERATOR_PLATFORM} GEN_PLATFORM)
        message(STATUS "Building MSVC for architecture ${CMAKE_SYSTEM_PROCESSOR} with CMAKE_GENERATOR_PLATFORM as ${GEN_PLATFORM}")
        if (${GEN_PLATFORM} STREQUAL "arm64")
            set(QNN_ARCH_ABI aarch64-windows-msvc)
        else()
            set(QNN_ARCH_ABI x86_64-windows-msvc)
        endif()
    else()
        if (CMAKE_SYSTEM_NAME STREQUAL "Android" AND ANDROID_ABI STREQUAL "arm64-v8a")
            set(QNN_ARCH_ABI aarch64-android)
        elseif (LINUX)
            if (${GEN_PLATFORM} STREQUAL "x64")
                set(QNN_ARCH_ABI x86_64-linux-clang)
            else()
                set(QNN_ARCH_ABI aarch64-ubuntu-gcc9.4)
            endif()
        endif()
    endif()
    if (QNN_ARCH_ABI)
        list(APPEND onnxruntime_LINK_DIRS ${onnxruntime_QNN_HOME}/lib/${QNN_ARCH_ABI})
    endif()
endif()

if (QNN_ARCH_ABI)
    file(
        GLOB QNN_SO_FILES
        LIST_DIRECTORIES false
        "${onnxruntime_QNN_HOME}/lib/${QNN_ARCH_ABI}/libQnn*.so"
        "${onnxruntime_QNN_HOME}/lib/${QNN_ARCH_ABI}/libHtp*.so"
        "${onnxruntime_QNN_HOME}/lib/${QNN_ARCH_ABI}/*_qnn.so"
        "${onnxruntime_QNN_HOME}/lib/${QNN_ARCH_ABI}/libqnn*.so"
        "${onnxruntime_QNN_HOME}/lib/${QNN_ARCH_ABI}/libcalculator.so"
        "${onnxruntime_QNN_HOME}/lib/${QNN_ARCH_ABI}/libPlatformValidatorShared.so"
        "${onnxruntime_QNN_HOME}/lib/${QNN_ARCH_ABI}/Qnn*.dll"
        "${onnxruntime_QNN_HOME}/lib/${QNN_ARCH_ABI}/Htp*.dll"
    )

    if(NOT QNN_SO_FILES)
        message(ERROR "QNN not found in ${onnxruntime_QNN_HOME}/lib/${QNN_ARCH_ABI} for platform ${CMAKE_GENERATOR_PLATFORM}")
    endif()

    if (QNN_ARCH_ABI STREQUAL "aarch64-windows-msvc")
        file(
            GLOB QNN_EXTRA_SO_LIBS
            LIST_DIRECTORIES false
            "${onnxruntime_QNN_HOME}/lib/hexagon-v66/unsigned/libQnnDspV66Skel.so"
            "${onnxruntime_QNN_HOME}/lib/hexagon-v68/unsigned/libQnnHtpV68Skel.so"
            "${onnxruntime_QNN_HOME}/lib/hexagon-v73/unsigned/libQnnHtpV73Skel.so"
            "${onnxruntime_QNN_HOME}/lib/hexagon-v73/unsigned/libqnnhtpv73.cat"
        )
    else()
        file(
            GLOB QNN_EXTRA_SO_LIBS
            LIST_DIRECTORIES false
            "${onnxruntime_QNN_HOME}/lib/hexagon-v*/unsigned/libQnn*Skel.so"
        )
    endif()
    if (QNN_EXTRA_SO_LIBS)
        list(APPEND QNN_SO_FILES ${QNN_EXTRA_SO_LIBS})
    endif()

    message(STATUS "QNN so/dlls in ${QNN_SO_FILES}")
endif()
