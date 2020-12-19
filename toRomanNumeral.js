exports.handler = (event, context, callback) => {

  const romanNumeral = toRomanNumeral(event.integer);

  callback(null, romanNumeral);
};

const toRomanNumeral = (int) => {
  const romanNumerals = [
    {number: 1000, letter: 'M'},
    {number: 900, letter: 'CM'},
    {number: 500, letter: 'D'},
    {number: 400, letter: 'CD'},
    {number: 100, letter: 'C'},
    {number: 90, letter: 'XC'},
    {number: 50, letter: 'L'},
    {number: 40, letter: 'XL'},
    {number: 10, letter: 'X'},
    {number: 9, letter: 'IX'},
    {number: 5, letter: 'V'},
    {number: 4, letter: 'IV'},
    {number: 1, letter: 'I'}
  ];

  let convertedNumber = "";
  for (const i in romanNumerals) {
    while (int >= romanNumerals[i].number) {
      convertedNumber += romanNumerals[i].letter;
      int -= romanNumerals[i].number;
    }
  }

  return convertedNumber;
};