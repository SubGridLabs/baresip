#!/usr/bin/gnuplot

# Set output format
set terminal png size 1400,900 font "Arial,12"
set output 'macos_improvement_chart.png'

# Multi-plot layout
set multiplot layout 2,2 title "macOS CI/CD Performance Analysis" font "Arial,18"

# Chart 1: Build Times Stacked Bar
set title "Build Time Breakdown by Phase" font "Arial,14"
set xlabel "Development Phase"
set ylabel "Time (minutes)"
set style data histograms
set style histogram rowstacked
set style fill solid border -1
set boxwidth 0.75
set xtics ("Failed" 1, "Basic" 2, "Upload" 3, "Cache" 4, "Future" 5)
set yrange [0:25]
set key top right

plot 'build_times.dat' using 2:xtic(1) title "Build Job" linecolor rgb '#e74c3c' fillstyle solid, \
     '' using 3 title "Test Job" linecolor rgb '#3498db' fillstyle solid

# Chart 2: Improvement Percentage
set title "Performance Improvement Over Time" font "Arial,14"
set xlabel "Development Phase"
set ylabel "Improvement (%)"
set style data linespoints
set xtics ("Failed" 1, "Basic" 2, "Upload" 3, "Cache" 4, "Future" 5)
set yrange [0:85]
set key bottom right
unset style
set pointsize 2

plot 'improvement_data.dat' using 1:4 with linespoints linewidth 3 pointtype 7 linecolor rgb '#27ae60' title "Speed Improvement"

# Chart 3: Component Analysis
set title "Test Job Performance Impact" font "Arial,14"
set xlabel "Phase"
set ylabel "Test Job Time (min)"
set style data linespoints
set yrange [0:16]
set pointsize 2

plot 'build_times.dat' using 1:3 with linespoints linewidth 3 pointtype 9 linecolor rgb '#f39c12' title "Test Job Duration"

# Chart 4: Success Rate
set title "Build Success Rate" font "Arial,14"
set xlabel "Phase"
set ylabel "Success Rate (%)"
set yrange [0:110]
set style fill solid
set boxwidth 0.5

plot 'build_times.dat' using 1:5 with boxes linecolor rgb '#2ecc71' fillstyle solid title "Success Rate"

unset multiplot
