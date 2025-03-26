%% applyADSR.m
% 作用：模拟自然乐器的振幅时间演化
%       该函数通过生成 ​ADSR包络​（Attack-Decay-Sustain-Release）对音频信号进行动态整形，
%       并实施动态压缩以防止削波。
% 作者：Hucxious
% 时间：2025.3.26更新
% 主要参数： y           输入信号
%           reverbTime  混响时间
%           Fs          采样频率
% 返回参数： y           处理后的信号  

function y_adsr = applyADSR(y, Fs, varargin)
    % 参数处理
    p = inputParser;
    addOptional(p, 'Attack', 0.01);     % 起音时间 (s)
    addOptional(p, 'Decay', 0.1);       % 衰减时间 (s)
    addOptional(p, 'Sustain', 0.7);     % 持续电平 (0~1)
    addOptional(p, 'Release', 0.4);     % 释音时间 (s)
    parse(p, varargin{:});
    
    % 包络生成（当输入信号过短时，总时长可能不足覆盖ADSR阶段）
    t_total = numel(y)/Fs;              % 输入信号总时长
    env = zeros(size(y));               % 包络容器
    
    % 各阶段样本数计算
    attack_samples = round(p.Results.Attack * Fs);
    decay_samples = round(p.Results.Decay * Fs);
    release_samples = min(round(p.Results.Release * Fs), numel(y));
    sustain_samples = numel(y) - attack_samples - decay_samples - release_samples;
    
    % 分段应用
    ptr = 1;
    % Attack
    env(ptr:ptr+attack_samples-1) = linspace(0,1,attack_samples);
    ptr = ptr + attack_samples;
    % Decay
    env(ptr:ptr+decay_samples-1) = linspace(1,p.Results.Sustain,decay_samples);
    ptr = ptr + decay_samples;
    % Sustain
    env(ptr:ptr+sustain_samples-1) = p.Results.Sustain;
    ptr = ptr + sustain_samples;
    % Release
    env(ptr:end) = linspace(p.Results.Sustain,0,numel(y)-ptr+1);
    
    % 应用包络
    y_adsr = y(:) .* env(:);
    
    % 动态压缩
    threshold = 0.9;
    peak = max(abs(y_adsr));
    if peak > threshold
        y_adsr = y_adsr * threshold/peak;
    end
end