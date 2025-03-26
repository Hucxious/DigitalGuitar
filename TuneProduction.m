%% 参数生成代码
% 该函数用于生成不同频率的参数，辅助调参从而确定频率，与实际电子吉他项目关系不大

L = 0.65;        % 固定弦长
T_range = [50, 200];  % 合理张力范围 (N)
rho_range = [0.0001, 0.01]; % 合理线密度范围 (kg/m)

% 生成音高序列 (G3-A5对应MIDI 55-81)
midiNumbers = 55:81;
numNotes = length(midiNumbers);

% 预分配存储
noteNames = cell(numNotes, 1);
freqs = zeros(numNotes, 1);
Ts = zeros(numNotes, 1);
rhos = zeros(numNotes, 1);

for i = 1:numNotes
    midi = midiNumbers(i);
    freq = 440 * 2^((midi-69)/12);  % 计算频率
    [T, rho] = optimizeParameters(freq, L, T_range, rho_range);
    
    % 存储参数
    noteNames{i} = midiToNoteName(midi);
    freqs(i) = freq;
    Ts(i) = T;
    rhos(i) = rho;
end

%% 结果展示
% 命令行输出
fprintf('弦长固定为 %.2f 米\n', L);
resultTable = table(noteNames, freqs, Ts, rhos,...
    'VariableNames', {'音高','频率(Hz)','张力(N)','线密度(kg/m)'});
disp(resultTable)

% 可视化参数分布
figure;
subplot(2,1,1)
plot(freqs, Ts, 'bo-')
ylabel('张力 (N)')
title('物理参数分布')
grid on

subplot(2,1,2)
semilogy(freqs, rhos, 'ro-')  % 对数坐标
ylabel('线密度 (kg/m)')
xlabel('频率 (Hz)')
grid on

%% 辅助函数
function [T, rho] = optimizeParameters(f, L, T_lim, rho_lim)
    % 优化函数找到合理参数组合
    c = @(T,rho) sqrt(T/rho);    % 波速方程
    
    % 通过线密度计算需要的张力
    rho = fzero(@(r) constrainTension(r,f,L,T_lim), mean(rho_lim));
    T = rho*(2*L*f)^2;
    
    % 边界约束
    rho = max(min(rho, rho_lim(2)), rho_lim(1));
    T = max(min(T, T_lim(2)), T_lim(1));
end

function err = constrainTension(rho,f,L,T_lim)
    % 约束张力在合理范围内
    T = rho*(2*L*f)^2;
    if T < T_lim(1)
        err = T - T_lim(1);  % 需要增大rho
    elseif T > T_lim(2)
        err = T - T_lim(2);  % 需要减小rho
    else
        err = 0;             % 在合理范围内
    end
end

function noteName = midiToNoteName(midiNumber)
    % MIDI编号转音高名称
    notes = {'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'};
    octave = floor(midiNumber/12) - 1;
    noteIndex = mod(midiNumber,12) + 1;
    noteName = [notes{noteIndex} num2str(octave)];
end