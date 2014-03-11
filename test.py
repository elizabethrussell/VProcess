import Image

img = Image.open("HR.png")
data = list(img.getdata())

print data