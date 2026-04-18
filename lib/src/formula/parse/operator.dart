enum Operator {
  not('!'),
  minus('-'),
  eq('=='),
  neq('!='),
  lt('<'),
  gt('>'),
  le('<='),
  ge('>='),
  add('+'),
  sub('-'),
  mul('*'),
  div('/'),
  and('&&'),
  or('||'),
  exp('^'),
  rem('%');

  final String symbol;
  const Operator(this.symbol);
}
