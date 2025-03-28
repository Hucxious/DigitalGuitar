# 项目介绍

  博主是一名正在学习数学物理方程的大二生，老师布置了一个利用波动方程制作电子吉他的小任务，恰好正在学习MATLAB的APP Designer，故尝试做了这么一个项目。

# 版本需求

  博主是MATLAB R2023b，其余没测试
  
# 主要文件

  |——SolveWaveEquation.m---//该函数用于求解波动方程，为核心解算文件
  
  |——applyADSR.m------------//该函数主要用ADSR包络对声音处理，使声音更符合乐器的声音
  
  |——applyReverb.m----------//该函数用于模拟混响效果
  
  |——StringTest.m-------------//该文件为MATLAB的直接运行文件，用于检测上述三个函数的效果或调整相关参数
  
  |——TuneProduction.m------//该文件用于生成不同音准的弦长、线密度和弦张力的参数，结果已在StringTest.m文件中贴出，故无明确作用
  
  |——DigitalGuitar.mlapp-----//该文件为APP Designer的核心文件，用于实现界面化设计和函数回调
  

# 使用说明

  在StringTest.m文件中直接运行即可解算在给定参数下的波动方程图形，同时函数中包含了傅里叶变换的频谱图，可用于进行波形和函数的测试。
  
  在DigitalGuitar.mlapp中运行即可生成可交互式的APP，用户可自行调整弦长、线密度、弦张力等相关参数，同时还可选择是否添加强迫力F，目前给出的F包括点激励和谐波激励。

# 写在最后

  该项目仅仅是博主用来学习波动方程和MATLAB的APP Designer的，欢迎大家讨论和交流问题。
