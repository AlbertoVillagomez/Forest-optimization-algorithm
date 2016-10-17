function z = func5(x)
    d = size(x, 2);
    sum = 0;
    prod = 1;
    for i = 1:d
        sum = sum + (x(i))^2/4000;
        prod = prod * cos(x(i)/sqrt(i));
    end

    z = sum - prod + 1;
end