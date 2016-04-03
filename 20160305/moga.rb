require 'bundler'
Bundler.require

def to_i(char)
  case char
  when '0'..'9'
    char.to_i
  when 'A'..'Z'
    char.ord - ?A.ord + 10
  when 'a'..'z'
    char.ord - ?a.ord + 36
  else
    binding.pry
    raise
  end
end

def count(ary)
  (x1, x2), (y1, y2) = ary
  (x1..x2).count * (y1..y2).count
end

def solve(input)
  n, blacks = input.scan(/(\d+):(.*)/).first
  n = n.to_i
  blacks = blacks.split(?,).map {|cs| cs.chars.map {|c| to_i(c) } }
  results = (0...62).to_a.repeated_combination(2).to_a.product((0...62).to_a.repeated_combination(2).to_a).select {|(x1, x2), (y1, y2)|
    blacks.count {|(x, y)| (x1..x2).cover?(x) && (y1..y2).cover?(y) } == n
  }.sort_by {|ary|
    count(ary)
  }
  min = count(results.first)
  max = count(results.last)

  "#{min},#{max}"

rescue
  '-'
end

def test(input, expect)
  actual = solve(input)

  if actual == expect
    puts "OK: #{input}"
  else
    raise "NG: #{input} : expect #{expect} but got #{actual}"
  end
end

DATA.each_line do |line|
  puts line
  eval line.match(%r{.*(test.*)}).captures.first
end

__END__
/*44*/ test( "9:Ic,Dk,Ef,6R,GK,NZ,76,L0,oQ,9f,S3,oL,lX,7v,8d,pX,dZ,z7,zx,fR,pe,w7,aj,U9,lO,kv,wL,s0", "396,2088" );
/*45*/ test( "10:JJ,LR,Xe,kg,LU,lI,3w,ZV,Td,Mu,tA,g8,VC,I7,N8,zN,kY,Ux,3t,mg,4m,FO,Ug,vQ,qY,jl,Ne,Zq,GN", "416,1794" );
/*46*/ test( "11:lQ,EN,vO,tn,qO,F3,9k,K2,UC,P0,XY,DB,QO,ps,hy,fl,Dt,ex,Vc,vF,Pf,Vk,uo,Xc,Sh,KE,9g,3H,l6", "658,1995" );
