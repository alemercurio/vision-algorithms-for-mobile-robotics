function [IMGud] = undistort_image(IMG, IMGd, K, D)
    IMGud = uint8(zeros(size(IMG, 1), size(IMG, 2)));
    for v=1:size(IMG, 1)
        for u=1:size(IMG, 2)
            r2 = (u-K(1,3))^2+(v-K(2,3))^2;
            coeff = 1 + D(1)*r2 + D(2)*r2^2;
            ud = round(coeff*(u-K(1,3))+K(1,3));
            vd = round(coeff*(v-K(2,3))+K(2,3));
            IMGud(v,u) = IMGd(vd,ud);
        end
    end
end