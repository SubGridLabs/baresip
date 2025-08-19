#!/usr/bin/env gnuplot

# Complete CI/CD Performance Story
set terminal png size 1200,800 font "Arial,12"
set output "complete_performance_story.png"

set title "Complete baresip CI/CD Performance Journey" font "Arial,18" enhanced
set xlabel "Optimization Phase" font "Arial,14"
set ylabel "Total Build Time (minutes)" font "Arial,14"

set grid ytics xtics
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.8

set xtics rotate by -20
set key top right
set key box

# Plot the data with value labels
plot 'cold_build_data.dat' using 3:xtic(2) with histogram linecolor rgb '#e74c3c' title "Build Time", \
     '' using ($0):($3):($3 < 1 ? sprintf("%.1f min", $3) : sprintf("%.1f min", $3)) with labels center offset 0,1 font "Arial,10" notitle

# Add improvement percentages as labels  
set label 1 "Baseline" at 0,26.5 center font "Arial,10" textcolor rgb '#2c3e50'
set label 2 "59% faster\nvs Cold Build" at 1,12 center font "Arial,10" textcolor rgb '#e67e22'
set label 3 "75% faster\nvs Cold Build" at 2,8 center font "Arial,10" textcolor rgb '#f39c12'
set label 4 "91% faster\nvs Cold Build" at 3,4.5 center font "Arial,10" textcolor rgb '#27ae60'

replot