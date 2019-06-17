use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    for n in 0..5 {
        let purity = args[1].parse::<f32>().unwrap();
        //log2( (1 - purity) + purity * (0:6 + .5) / ploidy )
        let i = 1. - purity + ((purity * n as f32) / 2.);
        print!("{}", n);
        print!("  ");
        println!("{}", i.log2());
    }
}
