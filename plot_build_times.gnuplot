#!/usr/bin/gnuplot

# Set output format and file
set terminal png size 1200,800 font "Arial,12"
set output 'macos_build_improvements.png'

# Chart styling
set title "macOS CI/CD Build Time Improvements" font "Arial,16" enhanced
set xlabel "Phase" font "Arial,14"
set ylabel "Time (minutes)" font "Arial,14"

# Grid and styling
set grid ytics
set style data histograms
set style histogram rowstacked
set style fill solid border -1
set boxwidth 0.75

# Colors for different components
set palette defined (1 '#ff6b6b', 2 '#4ecdc4', 3 '#45b7d1', 4 '#96ceb4', 5 '#ffeaa7')

# X-axis labels
set xtics ("Failed\nBuilds" 1, "Basic\nSuccess" 2, "Package\nUpload" 3, "Cache\nSharing" 4, "Future\nRuns" 5)

# Y-axis range
set yrange [0:25]

# Key/Legend
set key top right
set key box

# Plot the stacked bars
plot 'build_times.dat' using 2:xtic(1) title "Build Job" linecolor rgb '#ff6b6b' fillstyle solid, \
     '' using 3 title "Test Job" linecolor rgb '#4ecdc4' fillstyle solid

# Add annotations for key improvements
set label 1 "libx265 Fix\n+ Package ID" at 1.5,20 center font "Arial,10"
set label 2 "Package Upload\nOptimization" at 2.5,22 center font "Arial,10"
set label 3 "Cache Sharing\nFix" at 3.5,15 center font "Arial,10"
set label 4 "80% faster\ntest job!" at 4,8 center font "Arial,10" textcolor rgb '#ff6b6b'
set label 5 "78% total\nimprovement" at 5,12 center font "Arial,10" textcolor rgb '#ff6b6b'

replot
