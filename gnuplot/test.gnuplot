set terminal pdf font "Gill Sans,19" linewidth 4 rounded
set output "test.pdf"
plot "test.data" using 1:2
set output