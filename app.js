

var from = "02/11/1994".split("/");
var birthdateTimeStamp = new Date(from[2], from[1] - 1, from[0]);
var cur = new Date();
var diff = cur - birthdateTimeStamp;
var currentAge = Math.floor(diff/31557600000);
// printing out my age 
document.getElementsByClassName("age")[0].innerHTML = currentAge;
