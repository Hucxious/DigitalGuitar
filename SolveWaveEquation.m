%% SolveWaveEquation.m
% 作用：求解理想情况下的波动方程（可选择是否加入受迫力项）
%       该函数使主要使用有限差分法，在不考虑阻尼项的理想情况下，空间上对弦长采用等距网格划分，
%       时间上采用显式跳蛙法进行时间推进，同时采用了汉宁窗函数模拟拨弦动作，确保初始位移光滑
%       且满足边界条件。
% 作者：Hucxious
% 时间：2025.3.26更新
% 主要参数： T           弦张力
%           rho         弦密度
%           L           弦长
%           duration    持续时间
%           Fs          采样频率
% 返回参数： t           时间向量
%           y           振动位移


function [t, y] = SolveWaveEquation(T, rho, L, duration, Fs, varargin)
    % 参数校验
    validateattributes(T, {'numeric'}, {'positive'});
    validateattributes(rho, {'numeric'}, {'positive'});
    validateattributes(L, {'numeric'}, {'positive'});
    
    % 输入解析，确定是否含有受迫力及是否拨弦初始化
    p = inputParser;
    addParameter(p, 'ForceFunc', []);
    addParameter(p, 'EnablePluck', true);
    parse(p, varargin{:});
    
    % 物理参数计算
    c = sqrt(T/rho);            % 波动方程中系数c = sqrt(弦张力/弦密度)，c即波速
    max_freq = 2000;            % 最大模拟频率
    dx = c/(2*max_freq);        % Nyquist定理得初始空间步长dx
    Nx = max(3, ceil(L/dx));    % 空间网格点数，确保至少3个点
    dx = L/(Nx-1);              % 修正后的实际空间步长，使得dx更精确地适应弦长L
    
    % 时间离散
    dt = 1/Fs;                  % 时间步长
    Nt = ceil(duration*Fs);     % 总循环次数
    t = (0:Nt-1)*dt;            % 时间向量
    
    % 初始化位移场
    u = zeros(3, Nx);
    if p.Results.EnablePluck
        u(2,:) = hann_init(Nx);  % 汉宁窗初始化，模拟拨弦的初始位移分布
    end
    
    % 主循环
    y = zeros(1, Nt);
    for n = 1:Nt
        % 空间二阶差分计算（向量化操作）
        u_xx = (u(2,3:Nx) - 2*u(2,2:Nx-1) + u(2,1:Nx-2)) / dx^2;
        
        % 受迫力项（确保维度匹配）
        force = zeros(1, Nx-2);
        if ~isempty(p.Results.ForceFunc)
            x_pos = (1:Nx-2)*dx;    % 正确的位置向量
            force = p.Results.ForceFunc(x_pos, t(n));
            force = force(1:Nx-2);  % 强制截断匹配维度
        end
        
        % 更新方程（严格维度检查）
        u(3,2:Nx-1) = 2*u(2,2:Nx-1) - u(1,2:Nx-1) + ...
                      (c^2 * dt^2) * u_xx + ...
                      (dt^2/rho) * force(1:length(u_xx));
        
        % 记录输出（严格索引范围）
        y(n) = u(3, min(round(0.9*Nx), Nx));
        
        % 滚动更新
        u(1:2,:) = u(2:3,:);
    end
    
    % 汉宁窗函数：用于模拟拨弦动作
    function init = hann_init(N)
        x = linspace(0,1,N);
        init = 0.5*(1 - cos(2*pi*x));
    end

end