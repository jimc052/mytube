console.clear();
let options = document.querySelectorAll("#items a.ytd-grid-video-renderer");
let def =  {
  "author": "跟洋妞学英语", 
  "date": "2021/11/26 12:00:00", 
};
let arr = [];
for(let i = 0; i < options.length; i++) {
  let href = options[i].href.replace("https://www.youtube.com/channel/UC0FOq3KG1AXrHpWhVC6S8fQ/", "");
  href = href.replace("https://www.youtube.com/watch?v=", "");
  let title = options[i].innerHTML;
  let index = href.indexOf("&t=");
  if(index > -1) {
    href = href.substr(0, index);
  }
  
  // console.log(href + ": " + options[i].innerHTML)
  arr.push(Object.assign({
    key: href, 
    title
  }, def))
}
// arr.sort(function(a, b) {
// 	if(a.title > b.title)
// 		return 1;
// 	else if(a.title < b.title)
// 		return -1;
// 	return 0;
// })
console.log("\n\n" + JSON.stringify(arr))
// -------------------------
console.clear();
let options = document.querySelectorAll("#items a.ytd-grid-video-renderer");
let arr = [];
for(let i = 0; i < options.length; i++) {
  console.log(options[i].href + ": " + options[i].innerHTML)
  console.log(options[i])
}


let arr = [
  {
    "key": "a-RnOkTxhxE",
    "title": "ALCPT 107",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "4h8Fo8l3GwA",
    "title": "ALCPT 111",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "-UZCQfLZVSQ",
    "title": "ALCPT FORM 81",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "htlV4SQa-Mk",
    "title": "ALCPT FORM 84",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "iaVWQrpT_6Q",
    "title": "ALCPT FORM 87",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "WmPkfzc1F1o",
    "title": "ALCPT form 72",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "RXyBGXf2W7w",
    "title": "ALCPT form 73",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "sJNcYm1Cnuw",
    "title": "ALCPT form 75",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "lGcoR6EVbGU",
    "title": "ALCPT form 76",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "3YUvDJlzU6Y",
    "title": "ALCPT form 77",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "ZQowNSe9mak",
    "title": "ALCPT form 78",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "IAr-IyEYV7I",
    "title": "ALCPT form 79",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "aHVGP20liAI",
    "title": "ECL   Listening Script  Reading – Version 1",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "rtLKj98xCiw",
    "title": "ECL   Listening Script  Reading – Version 2",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "NlGIMHYnw4Y",
    "title": "ECL   Listening Script  Reading – Version 3",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "fMTkIGxd6Io",
    "title": "ECL   Listening Script  Reading – Version 4",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "4jdKsqIguqA",
    "title": "ECL   Listening Script  Reading – Version 5",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "SqIesid5H9Q",
    "title": "ECL 59",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "nYEe1HrznqM",
    "title": "ECL A12",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  },
  {
    "key": "IW930Dr7q4U",
    "title": "ECL TEST FORM E17",
    "author": "ALCPT & ECL",
    "date": "2021/11/12 13:00:00",
    "fileName": ""
  }
];