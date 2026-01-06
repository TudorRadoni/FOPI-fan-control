function reccurenceRelFromNumDen(n,d)

format long;
string = 'ck = ';

for i = 1:length(n)
    if (n(i)>0) 
        string2 = '+';
    else 
        string2='';
    end
    
    string2 = strcat(string2, num2str(n(i), 15));
    if i==1
        string3 = strcat(string2, 'e(k)');
    else 
        string3 = strcat(string2, 'e(k-', num2str(i-1), ')');
    end
    
    string = strcat(string, string3);
end

d = d * -1;
for i = 2:length(d)
    
    if (d(i)>0) 
        string2 = '+';
    else 
        string2='';
    end
    
    string2 = strcat(string2, num2str(d(i), 15));
    string3 = strcat(string2, 'c(k-', num2str(i-1),')');    
    string = strcat(string, string3);
end

string = strcat(string, ';')

end