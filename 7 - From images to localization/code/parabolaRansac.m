function [best_guess_history, max_num_inliers_history] = ...
    parabolaRansac(data, max_noise)
% data is 2xN with the data points given column-wise, 
% best_guess_history is 3xnum_iterations with the polynome coefficients 
%   from polyfit of the BEST GUESS SO FAR at each iteration columnwise and
% max_num_inliers_history is 1xnum_iterations, with the inlier count of the
%   BEST GUESS SO FAR at each iteration.

%rng(2);
max_iter = 100;
i = 1;

best_guess_history = zeros(3, max_iter);
max_num_inliers_history = zeros(1, max_iter);

while i<=max_iter
    datas = datasample(data, 3, 2, 'Replace', false); % 3 = number of points extracted; data is 2xN, 2 = second dimension = N
    fit = polyfit(datas(1,:), datas(2,:), 2); % x, y, rank; rank=2 because it is a parabola
    residual = abs(data(2,:)-polyval(fit, data(1,:)));
    inliers = data(:,residual<=max_noise);
    if i==1 || length(inliers) > max_num_inliers_history(i-1)
         max_num_inliers_history(i) = length(inliers);
         best_guess_history(:,i) =  polyfit(inliers(1,:), inliers(2,:), 2)'; % better then fit' because fits only the inliers
    else
        max_num_inliers_history(i) = max_num_inliers_history(i-1);
        best_guess_history(:,i) = best_guess_history(:,i-1);
    end
    i=i+1;
end
k = log(1-0.99)/log(1-(max_num_inliers_history(i-1)/length(data))^3)

end