let grades = [
    {
        'name': 'David',
        'marks': 80
    },
    {
        'name': 'Vinoth',
        'marks': 77
    },
    {
        'name': 'Divya',
        'marks': 88
    },
    {
        'name': 'Ishitha',
        'marks': 95
    },
    {
        'name': 'Thomas',
        'marks': 68
    }
];

let total = 0;

for(let i=0; i< grades.length; i++){
    total += grades[i].marks;
}

let average = total/grades.length;
let grade = '';

if(average<60)
    grade = 'F';
else if(average<70)
    grade = 'D';
else if(average<80)
    grade = 'C';
else if(average<90)
    grade = 'B';
else if(average<100)
    grade = 'A';