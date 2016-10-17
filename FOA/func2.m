function z = func2(x)
  sum = 0.0;
  for i=1:size(x, 2)
      sum = sum + abs(x(i))^(i+1);
  end
  z = sum;
end