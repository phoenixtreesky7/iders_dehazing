function [t_id_gif, t_id, parameters] = id_main(image_hazy, t, subsampling, iteration_max)
t_id_gif = 0;
% This code is used to estimate the final refining transmission ultilating IDeRS model.
%
% Input - image_hazy :   the color image
%                             t :   pixel-wise and patch-wise transmission maps in t{.} cell
%                            w :   scale of the Gaussion window
%                           W :   Weight of different scale in fusion
%                            N :   Scale number
%                          pic :   the pic number in path_IDeRS
% Output -  t_id_gif :   refined transmission map smoothed by fast GD-GIF
%                      t_id :   refined transmission map without smoothed
%
% Dong Zhao  2016.11.01

path_IDeRS = 'F:\1_MyWork\GitHub\iders_dome\IDeRS\';

if ~exist(path_IDeRS)
    mkdir(path_IDeRS);
end

    w=[5,11,17,23,29,35,41,47,53,60] ;                         % window size for Gaussian filter
    N = size(t, 1);    

[x, y] = size(t{1});
t_id{1}  = t{N};

% different Decolorization Algorithms you can try
imagegray = GcsDecolor2(image_hazy);
%imagegray = SPDecolor(image_hazy);
%imagegray = rgb2gray(image_hazy);

diff_t = cell(N-1,1);   diff_t_gau = cell(N-1,1);    diff_t_sig = cell(N-1,1);  diff_t_iter = cell(N-1,1);

%% IDeRS
xi = zeros(1, iteration_max); 
mean_t_n = zeros(1, iteration_max + 1);
xi(1) = 0.001;
mean_t_inf = mean(mean(t{1}));
iteration_stop = -1;
for iteration = 1 : iteration_max
    iteration

    if iteration == 1
        mean_t_n(iteration) = mean(mean(t_id{iteration}));
        
        if mean_t_n(1) - mean_t_inf < 0.1      %%   CLASS B  %%
            Gamma = 0;
            iteration_stop = 0;
        end
        
        Gamma = 0.25 * (mean_t_n(iteration) - mean_t_inf) + mean_t_inf;
    else
        xi(iteration) = 1/5 * sqrt(mean_t_n(iteration-1) - mean_t_n(iteration));
    end
    
    % --   D_t  -- %
    diff_t{iteration} = max( t_id{iteration} - t{1}, 0.001 );
    %imagesc( diff_t{iteration}, [0 1]); colormap jet;axis off  % colorbar('FontSize',30, 'FontWeight','bold'); axis image;
    %saveas(gcf,[ path_IDeRS 'IDeRS_'  num2str(pic) '_diff' num2str(iteration) ],'png');
    
    % --  D_g  -- %
    gaussian_kernel = fspecial( 'gaussian', [ 17, 17 ], 0.618 );
    diff_t_gau{iteration} = imfilter( diff_t{iteration}, gaussian_kernel, 'conv', 'same', 'replicate' );
    %imagesc( diff_t_gau{iteration}, [0 1]); colormap jet; axis off % colorbar('FontSize',30, 'FontWeight','bold'); axis image;
    %saveas(gcf,[ path_IDeRS 'IDeRS_'  num2str(pic) '_gaus' num2str(iteration) ],'png');
    
    % --  D_s  -- %
    a = w(iteration) -5;
    b = 0.618;   c = 1+exp(-b*(10-a));
    diff_t_sig{iteration} = image2D_logistic(diff_t_gau{iteration}, a, b, c);
    diff_t_sig_non{iteration} = 1 - diff_t_sig{iteration};
    
    % --  t_id  -- %
    t_id{iteration + 1} = diff_t_sig_non{iteration} .* t_id{iteration} + diff_t_sig{iteration} .* t{1};
    %imagesc( diff_t_iter{iteration} , [0 1]); colormap jet; axis off % colorbar('FontSize',30, 'FontWeight','bold'); axis image;
    %saveas(gcf,[ path_IDeRS 'IDeRS_'  num2str(pic) '_tIDeRS' num2str(iteration) ],'png');
    
    mean_t_n(iteration+1) = mean(mean(t_id{iteration + 1}));
    if iteration > 1
        if (mean_t_n(iteration + 1) - xi(iteration)) < Gamma  && Gamma ~= 0  &&...
                (mean_t_n(iteration) - xi(iteration - 1)) >= Gamma  %%  CLASS A  %%
            iteration_stop = iteration;
        end
    else
        if (mean_t_n(iteration + 1) - xi(iteration)) < Gamma  && Gamma ~= 0  %%  CLASS A  %%
            iteration_stop = iteration;
        end
    end
    
end
if iteration_stop == -1
    iteration_stop = iteration;
end
parameters = [ mean_t_n, mean_t_inf, Gamma, xi, iteration_stop ];
%% Fast GD-GIF
% --  t_id_gif    -- %
if iteration_stop == 0
    t_id{iteration_stop + 1} = t_id{iteration_stop + 1} * 0.75;
end
eps = 10^-3;
[t_id_gif, chi_I, weight, gamma, mean_a, mean_b] = gradient_guidedfilter_fast(imagegray, t_id{iteration_stop + 1}, eps, subsampling );
t_id_gif = min(max(t_id_gif, 0.1), 1);
%imagesc( t_id_gif, [0 1]); colormap jet; axis off % colorbar('FontSize',30, 'FontWeight','bold'); axis image;
%saveas(gcf,[ path_IDeRS 'IDeRS_'  num2str(pic) '_tcomgif'  ],'png');






