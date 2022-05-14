const fs = require('fs');

function splitNameByVariations(nameString){
        const allSubstrings = new Set();
        const start = 0;
        const splittedName = nameString.split(' ');
        for (let j = 0; j < splittedName.length; j++) {
            for (let i = start + 1; i <= splittedName[j].length; i++) {
                allSubstrings.add(splittedName[j].substring(start, i).toLowerCase());
            }
        }
        let a = 0;
        while (a < splittedName.length) {
            let possibleSubStrs = '';
            for (let i = a; i < splittedName.length; i++) {
                possibleSubStrs += splittedName[i];
                if (i < splittedName.length - 1) {
                    possibleSubStrs += ' ';
                }
            }
            for (let i = start + 1; i <= possibleSubStrs.length; i++) {
                allSubstrings.add(possibleSubStrs.substring(start, i).toLowerCase());
            }
            a++;
        }
        for (let i = start + 1; i <= nameString.length; i++) {
            allSubstrings.add(nameString.substring(start, i).toLowerCase());
        }
        const arr = Array.from(allSubstrings.values());
        return arr;
    }
    const data = {
    	foods: [
        /* Ételek JSON formátumban */
      ]
    }

data.foods.forEach((node) => node.nameSearchField = splitNameByVariations(node.foodName));
let towrite = JSON.stringify(data, null, "\t");
fs.writeFileSync('searchfield.json', towrite);