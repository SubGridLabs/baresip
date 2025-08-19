#!/usr/bin/gnuplot

# Set output format
set terminal png size 1200,800 font "Arial,12"
set output 'macos_build_evolution.png'

# Chart styling
set title "macOS Build Time Evolution - Real Measured Data" font "Arial,16" enhanced
set xlabel "Optimization Phase" font "Arial,14"
set ylabel "Time (minutes)" font "Arial,14"

# Grid and styling
set grid ytics
set style data histograms
set style histogram rowstacked
set style fill solid border -1
set boxwidth 0.6

# X-axis labels
set xtics ("Before\nOptimizations\n(Run 17052415551)" 1, "Partial\nOptimizations\n(Run 17053164802)" 2, "Latest\nOptimizations\n(Run 17053326338)" 3)

# Y-axis range
set yrange [0:12]

# Key/Legend
set key top right
set key box

# Plot the stacked bars with real data
plot 'macos_only_times.dat' using 3:xtic(1) title "Build Job" linecolor rgb '#e74c3c' fillstyle solid, \
     '' using 4 title "Test Job" linecolor rgb '#3498db' fillstyle solid

# Add improvement annotations
set label 1 "8.2 + 1.8 = 10.0 min" at 1,11 center font "Arial,10"
set label 2 "3.9 + 2.2 = 6.1 min\n(39% faster)" at 2,7.5 center font "Arial,10" textcolor rgb '#27ae60'
set label 3 "1.2 + 0.9 = 2.1 min\n(79% faster!)" at 3,3.5 center font "Arial,10" textcolor rgb '#e74c3c'

replot
