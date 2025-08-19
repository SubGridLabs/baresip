#!/usr/bin/gnuplot

# Set output format
set terminal png size 1000,600 font "Arial,12"
set output 'macos_improvement_trend.png'

# Chart styling
set title "macOS CI/CD Performance Improvement" font "Arial,16" enhanced
set xlabel "Optimization Phase" font "Arial,14"
set ylabel "Total Pipeline Time (minutes)" font "Arial,14"

# Grid and styling
set grid ytics xtics
set style data linespoints
set pointsize 3

# X-axis labels
set xtics ("Before\nOptimizations" 1, "Partial\nOptimizations" 2, "Latest\nOptimizations" 3)

# Y-axis range
set yrange [0:11]

# Key/Legend
set key top right
set key box

# Plot the trend line
plot 'macos_only_times.dat' using 1:5 with linespoints linewidth 3 pointtype 7 linecolor rgb '#e74c3c' title "Total Build Time", \
     '' using 1:3 with linespoints linewidth 2 pointtype 9 linecolor rgb '#3498db' title "Build Job Only", \
     '' using 1:4 with linespoints linewidth 2 pointtype 11 linecolor rgb '#f39c12' title "Test Job Only"

# Add improvement percentages
set label 1 "10.0 min\n(Baseline)" at 1,10.5 center font "Arial,10"
set label 2 "6.1 min\n(39% improvement)" at 2,6.8 center font "Arial,10" textcolor rgb '#27ae60'
set label 3 "2.1 min\n(79% improvement!)" at 3,2.8 center font "Arial,10" textcolor rgb '#e74c3c'

replot
