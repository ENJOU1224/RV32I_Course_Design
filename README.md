# 暂存一下作业

RT,但是后续的CPU可能也会基于这个作业

2022.3.24 16:03:39 完成了decode和开始动工ALU，目前单周期，故计划在ALU里完成PC+4，后续计划PC+4向后传输来减轻取消后续单独计算PC+4模块，然后把加法器用去计算跳转地址输出。还单独做了分支跳转模块，里面带了比较器和相等判断器件来服务分支语句是否执行。

2022.3.25 22:38:08 完成了ALU，还有Memory和WB还有IF需要完成。。。。不过应该不麻烦

2022.3.28 17:56:16 完成了编码，正在测试，貌似目前还没发现大问题
