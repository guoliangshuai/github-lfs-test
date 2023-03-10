#!/bin/bash
WORKDIR=$(pwd)

# 通用基础环境js
function copy_base() {
    rm -rf output/*
    # 通用测基础环境 jupyterlab-extensions
    wget -O output.tar.gz --no-check-certificate --header "IREPO-TOKEN:49e7c21d-7463-43bb-a027-1e1d98b0e0ab" "https://irepo.baidu-int.com/rest/prod/v3/baidu/webide/jupyterlab-extensions/releases/1.5.3.8/files"
    tar zxvf output.tar.gz
    # 理论上codelab需要推到cdn上
    mv output/static codelab
    cd output
    echo "安装 jupyterlab"
    python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple *.whl
    rm -rf ../output
}

# 通用侧自定义插件选择
function copy_plugin() {
    # 通用插件产出
    # 目前包含插件 codelab_code_snippet_ext	codelab_environment_info	codelab_package_dis_ext		codelab_pipeline_plugin		codelab_resource_monitor	codelab_visualdl_extension
    path_list="/codelab_code_snippet_ext /codelab_code_snippet_ext /codelab_environment_info /codelab_package_dis_ext /codelab_resource_monitor /codelab_visualdl_extension"
    wget -O output.tar.gz --no-check-certificate --header "IREPO-TOKEN:486b0505-3d7a-40c1-933b-72d23162559a" "https://irepo.baidu-int.com/rest/prod/v3/baidu/webide/jupyterlab-extensions/releases/1.5.3.9/files"
    tar zxvf output.tar.gz
    # 缓存依赖
    for path in $path_list;
    do
      cp -r $WORKDIR/output/packages$path $WORKDIR/packages
    done
}

function build() {
    copy_base
    cd "$WORKDIR"
    # 线上需要替换为 yarn build:aistudio
    echo "插件编译"
    yarn && yarn build:aistudio:lib && yarn build:aistudio:extension
    echo "复制通用插件"
    copy_plugin
    echo "打包"
    rm -rf output
    mkdir -p output
    mv codelab/build ./output/codelab
    npx  codelab-extension -p ./packages ./ -o ./output
    mv output/output output/extensions
}
build