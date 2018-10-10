
% This is a Matlab re-implementation of the paper.
%
% Multi-scale Optimal Fusion Model for Single Image Dehazing
%
% Dong Zhao, Long Xu, Yihua Yan, Jie Chen, Lingyu Duan
% 2018.07.23


close all
clear all
clc


path_IDeRS = 'F:\1_MyWork\GitHub\iders_dome\IDeRS\result\';  % your path for results saving
path_input = 'F:\1_MyWork\GitHub\iders_dome\data\';  % your path for input reading

if ~exist(path_IDeRS)
    mkdir(path_IDeRS);
end
% if ~exist(path_input_shrink)
%     mkdir(path_input_shrink);
% end
%%  Image Reading
imgDataDir  = dir(path_input);
for ifile = 1 : 3
    if (isequal(imgDataDir(ifile).name, '.')||...
            isequal(imgDataDir(ifile).name, '..')||...
            imgDataDir(ifile).isdir)
        continue;
    end
    image_name = dir([path_input '*.png']);
end

%% Parameters Setting
denoise = 0;
subsampling = 3;
iteration_max = 5;
resolution_max = 1300;

RunningTime = zeros(1,  size(image_name, 1))';
PixleNumber = zeros(1,  size(image_name, 1));

%% iders Dehazing
for pic = 1 : 1 : size(image_name, 1)
    pic
    
    image_hazy = im2double(imread(strcat(path_input, image_name(pic).name)));
    [image_h, image_w, image_c] = size(image_hazy);
    PixleNumber(pic) = image_h * image_w;
    
    %%   A
    t1 = clock;
    
    gamma = 1;
    [ hazeline_A ] = reshape( estimate_airlight( image_hazy .^ (gamma)), 1, 1, 3 )
    A(pic, :) = hazeline_A;
    
    % display of hazeline_A
    % hazeline_A(pic, :)_figure(:,:,1) = hazeline_A(pic, :)(1)*ones(50*50);
    % hazeline_A(pic, :)_figure(:,:,2) = hazeline_A(pic, :)(2)*ones(50*50);
    % hazeline_A(pic, :)_figure(:,:,3) = hazeline_A(pic, :)(3)*ones(50*50);
    % figure,imshow([hazeline_A(pic, :)_figure])
    % saveName = [path_IDeRS 'iders_' num2str(pic) '_A_hl'  '.png'];
    % imwrite(hazeline_A(pic, :)_figure, saveName);
    
    
    %% Transmission t Estimating and Refining
    
    dcpR(1) = 3 * floor(log10(PixleNumber(pic)));
    
    image_norm = zeros(size(image_hazy));
    for index = 1 : 3
        image_norm(:, :, index) = image_hazy(:, :, index) ./ A(pic, index);
    end
    
    [dark_patch, dark_pixel] = dcp_multiscale(image_norm, dcpR);
    t = cell(length(dcpR) + 1, 1);
    
    omega = 0.9;
    t{1} = max(min( 1 - omega * dark_pixel, 1), 0 );
    for index = 2 : length(dcpR) + 1
        t{index} = min( 1 - omega * dark_patch{index - 1}, 1 );
    end
    
    % refine t using iders model
    parameters(pic, :) = zeros(1, ( iteration_max + 1 ) + 1 + 1 + 1 + iteration_max );   %  mean_t_n : 0 - iteration_max;  mean_t_inf;  Gamma;  iteraion, respectively
    
    [ t_id_gif, t_id, parameters(pic, : ) ] = id_main( image_hazy, t, subsampling, iteration_max);
    
    %% Dehazing
    dehazingiders = getRadiance( A(pic, :), image_hazy, t_id_gif );
    
    %% Exposure Enhancement
    % --  LIME  -- %
    % Guo X, Li Y, Ling H. LIME: Low-light image enhancement via illumination map estimation[J]. IEEE Transactions on Image Processing, 2017, 26(2): 982-993.
    dehazingiders_E = im2double(image_exposure(dehazingiders, denoise));
    
    % running time
    t2=clock;
    RunningTime(pic) = etime(t2, t1) ;
    
    %% Results Saving
    figure(1), imshow( [image_hazy, dehazingiders_E] );
    saveName = [path_IDeRS 'IDeRS_' (image_name(pic).name(1 : end - 4) ) '_S' num2str(subsampling) '_I' num2str(parameters(pic, end)) '.png']
    imwrite(dehazingiders_E, saveName);

    'END'
    
end


