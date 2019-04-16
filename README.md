## 懒人神器
**一键build：zip -> jar**

由于每次互测都要经过重复的操作：

> download -> unzip -> compile -> run

本着一懒到底的原则，以及想要进一步熟悉一下shell指令，写了一个builder的脚本。

自己留着没意思，就拿出来分享给大家了，慢慢享用。



### 使用

- 将所有下载的zip压缩包（java源文件）放入src文件夹中
- 将本次作业的两个官方接口（外部jar包）放入lib文件夹中
- 在 `2.` 中，更改相应的lib文件的绝对路径
- 保证最后文件目录树如下即可：

```
├──src
│  ├─ Archer
│  ├─ Berserker
│  ├─ Caster
|  ├─ ....
|  └─ Alterego
├──lib
│  ├─ elevator-input-hw3-1.4-jar-with-dependencies.jar
│  └─ timable-output-1.1-raw-jar-with-dependencies.jar
└──builder.sh
```

- 注意如果有player上交的src文件有多个main入口，有可能会出错。（但同样的，如果上交文件包含有多个入口，官方评测可能也过不了，这也是为什么rules中规定只能有一个路口）

### 实现思路
#### 1. 解压缩并将lib中的外部包导入相应目录内
easy
#### 2. 将src文件夹下的java编译为class文件
- 编译输出路径为`player/out/`
- 注意 `lib`中的 -classpath 为绝对路径
#### 3. 将*.class打包成jar
- 难点（~~坑点~~） 在于`MANIFEST.mf` 的写入
    1. 保证 Main-Class: 带有相应的**包路径** ，如 `elevator3.Main`
    2. 保证 Class-Path: 为**相对路径**
    3. 保证文件后有两个空行。
- 因此，为满足上述需求：
    - 由于.class为二进制文件，无法直接解析，但out文件夹下的.class文件结果与.java相同，故可以通过`grep`检索`.java`文件，得到Main类包路径，再对得到的路径进行**标准格式化**操作即可。
    - 相对路径： `.`表示当前路径；`..`表示上一目录的路径
    - ~~需要有空行是真的坑，差点自闭···~~


### 源码

```sh


#!/bin/bash

# Pre-Condition: 
# NOTHING

# Attention:
# *.zip will be deleted

# Procedure:
# 1. put all *.zip into the src/ folder
# 2. put the external .jar into lib/ folder
# 3. run './builder.sh' 
# 4. the jar-files has been generated in the 'out' folder of the corresponding directory, enjoy!

# file-tree is as follows:
# dir
#  ├──src
#  ├──lib
#  └──builder.sh

cd src/
# 1. unzip and copy lib/ to src/
echo unzip start...

ls *.zip > temp.txt
sed 's/.zip//g' temp.txt > names.txt # sed 's/src/dst/'
names=`cat names.txt`   # attention

# echo $names
for name in ${names[@]}
do
    mkdir $name
    unzip $name.zip -d $name
    cp -a ../lib $name
done

rm *.txt
rm *.zip
echo unzip successfully...


# 2. compile to class
echo complie start...

prefix="javac -encoding utf-8 -d out/ @srcpath.txt "
lib="-classpath /C/Users/94831/Desktop/CourseCenter/OO/testShell/lib/elevator-input-hw3-1.4-jar-with-dependencies.jar:/C/Users/94831/Desktop/CourseCenter/OO/testShell/lib/timable-output-1.1-raw-jar-with-dependencies.jar "
command=${prefix}${lib}

dirs=`ls`
echo $dirs

for dir in ${dirs[@]}
do
    # echo $dir
    cd $dir
    mkdir out
    find -name "*.java" > srcpath.txt
    $command
    # rm srcpath.txt
    cd ..
done

echo compile successfully...


# 3. pack to jar
echo packing to jar...

for dir in ${dirs[@]}
do
    echo $dir
    cd $dir
    # write config information to MANIFEST.mf
    echo -n 'Main-Class: ' > MANIFEST.mf
    grep -l "public static void main" . -r | sed s/\\.\\///g | sed s/src\\///g | sed s/\\.java//g | sed s/\\//./g >> MANIFEST.mf
    sed '2, $d' MANIFEST.mf | tee MANIFEST.mf
    echo 'Class-Path: ../lib/elevator-input-hw3-1.4-jar-with-dependencies.jar ../lib/timable-output-1.1-raw-jar-with-dependencies.jar' >> MANIFEST.mf
    echo >> MANIFEST.mf
    mv MANIFEST.mf out

    cd out
    find -name "*.class" > classpath.txt
    jar cvfm $dir.jar MANIFEST.mf @classpath.txt
    cd ..   # from out
    cd ..   # from player_dir
done

echo pack successfully...



```


#### 如有问题，欢迎留言交流！