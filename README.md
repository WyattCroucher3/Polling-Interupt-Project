# Polling-Interupt-Project
Implementation of a single-digit adder in assembly.

Project for CptS260 at Washington State - Computer Architecture
Created November 15, 2021
Programmer: Wyatt Croucher

This is an assembly program used to determine the sum of two single-digit numbers. The user will type in 
an equation in the form of “ # + # =” and when the “=” key is pressed, the program will perform the 
calculation and display the result to the screen in the form “ # + # = #” OR “ # + # = ##” depending on the 
sum. The polling method is constantly checking for user input, whereas the interrupt method the CPU is 
notified that the user input needs to be processed. This program was developed using the MARS MIPS simulator, 
and output was tested using the Keyboard and Display MMIO Simulator tool. 
