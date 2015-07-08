#!/bin/sh
#brew install apktool
#brew install dex2jar

#d2j-dex2jar Contacts.apk

#http://blog.sina.com.cn/s/blog_70677d110100xzht.html
#使用baksmali和smali反编译和编译apk 
#java -jar baksmali-1.3.2.jar -o classout/ classes.dex   
#java -jar smali-1.3.2.jar classout/ -o classes.dex

#get smail后
#http://blog.sina.com.cn/s/blog_70677d110100wufa.html


#将apk文件后缀改成rar，然后解压，取出其中的classes.dex，放到任意位置；
#2.进入cmd，cd到dex2jar所在文件夹，输入命令dex2jar.bat %classes.dex所在目录%\class.dex
#3. 命令完成后在%class.dex所在目录%就会生成jar文件
#jd_gui:能够将jar文件反编译成java代码
#用法:
#打开jd_gui,然后将jar包拖放到主界面，就可以看到源代码了。