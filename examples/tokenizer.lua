require("strutil")

T=strutil.TOKENIZER("this,that,the other;and some:more",",");
token=T:next();
while (token ~=nil)
do
print(token)
token=T:next();
end
