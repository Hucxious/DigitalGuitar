%% applyReverb.m
% 作用：为波形添加混响效果
%       该函数通过卷积运算模拟混响效果，其核心原理是将输入信号与表征声场衰减特性的
%       脉冲响应（Impulse Response, IR）进行卷积，生成具有空间感的声音信号。通过
%       指数衰减包络近似封闭空间中的声能衰减过程。
% 作者：Hucxious
% 时间：2025.3.26更新
% 主要参数： y           输入信号
%           reverbTime  混响时间
%           Fs          采样频率
% 返回参数： y           处理后的信号  

function y_reverb = applyReverb(y, Fs, reverbTime)
    % 参数校验
    if reverbTime <= 0
        y_reverb = y;
        return
    end
    
    % 生成指数衰减包络
    t_decay = 0:1/Fs:reverbTime;    % 离散时间向量
    env = exp(-5*t_decay);
    
    % 使用'valid'卷积模式控制输出长度
    y_reverb = conv(y(:), env(:), 'valid');
    
    % 截断/填充至原始长度，使长度匹配
    if length(y_reverb) < length(y)
        y_reverb(end+1:length(y)) = 0;
    else
        y_reverb = y_reverb(1:length(y));
    end
end