let elements = [10, 20, 5, 87, 11, 10, 20, 5, 9];

for(let i=1; i<elements.length; i++){
    if(elements.indexOf(elements[i])!=i)
        console.log("found a duplicate at index "+i+" which is "+elements[i]);
}
