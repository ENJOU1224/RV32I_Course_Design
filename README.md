# 暂存一下作业

RT,但是后续的CPU可能也会基于这个作业

2022.3.24 16:03:39 完成了decode和开始动工ALU，目前单周期，故计划在ALU里完成PC+4，后续计划PC+4向后传输来减轻取消后续单独计算PC+4模块，然后把加法器用去计算跳转地址输出。还单独做了分支跳转模块，里面带了比较器和相等判断器件来服务分支语句是否执行。

2022.3.25 22:38:08 完成了ALU，还有Memory和WB还有IF需要完成。。。。不过应该不麻烦

2022.3.28 17:56:16 完成了编码，正在测试，貌似目前还没发现大问题

2022.4.9 14:54:35  测试了蛮多指令，没完全搞定，有时间继续。

2022.5.5 22:48:38 完成了单周期的测试，没问题，准备流水，存一下

2022.5.6 23:47:29 整完了除了前递和暂停以外的结构，准备前递，暂停现在有现成的套路了。应该可用。

2022.5.7 17:24:13 前递和暂停搞定，add测试通过，希望进度很快了。

2022.5.7 19:18:09 测试完毕，前面的版本没解决写后读，这个解决了。没问题了。
