// === Slowd + Glitch Player with Gradual Chaos ===

// Path to your audio file
"/2.wav" => string filePath;

// Buffer to hold the file
SndBuf buf => Gain g => dac;

// Load file
filePath => buf.read;
0 => buf.pos;

// Initial playback speed
0.5 => buf.rate;

// Master volume
0.8 => g.gain;

// Initial glitch parameters
0.5::second => dur glitchSize;   // size of each glitch jump
0.5 => float glitchChance;        // probability of glitching

// Chaos parameters
0.05 => float minRate;            // slowest absolute rate allowed
2.0 => float maxRate;             // fastest absolute rate allowed
0.01 => float chaosRateStep;      // how much we expand speed range each cycle
0.05 => float chaosGlitchStep;    // how much we increase glitch chance each cycle
15::minute => dur chaosInterval;  // how often chaos increases
8 => int chaosCycles;             // how many chaos increases before max chaos

// Chaos state tracker
0 => int chaosLevel;

// Chaos increaser
fun void chaosEvolution() {
    while (chaosLevel < chaosCycles) {
        chaosInterval => now;
        chaosLevel++;
        
        // Widen rate range
        minRate - chaosRateStep => minRate;
        maxRate + chaosRateStep => maxRate;
        if (minRate < -4.0) -4.0 => minRate; // cap extremes
        if (maxRate > 4.0) 4.0 => maxRate;
        
        // Increase glitch chance
        glitchChance + chaosGlitchStep => glitchChance;
        if (glitchChance > 1.0) 1.0 => glitchChance;
        
        <<< "[CHAOS]", "Level:", chaosLevel, 
            "Rate range:", minRate, "to", maxRate, 
            "Glitch chance:", glitchChance >>>;
    }
}

// Start chaos evolution in a sporked shred
spork ~ chaosEvolution();

// Main loop
while(true)
{
    // Decide whether to glitch
    if (Math.random2f(0,1) < glitchChance)
    {
        // Pick random position in buffer
        Math.random2(0, buf.samples()) => buf.pos;
    }
    
    // Occasionally change speed in chaos mode
    if (Math.random2f(0,1) < glitchChance/4) {
        Math.random2f(minRate, maxRate) => float r;
        if (Math.fabs(r) < 0.05) r + 0.1 => r; // avoid near zero
        r => buf.rate;
    }
    
    glitchSize => now;
}