const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');
const app = express();

app.use(cors());

const port = process.env.PORT || 5000;

const months = {
    "01": "Jan",
    "02": "Feb",
    "03": "Mar",
    "04": "Apr",
    "05": "May",
    "06": "Jun",
    "07": "July",
    "08": "Aug",
    "09": "Sep",
    "10": "Oct",
    "11": "Nov",
    "12": "Dec"
}

function isvalid(value) {
    return (value !== null && value !== '' && value !== undefined);
}

function getDate(date) {
    let rawDate = date.slice(0, date.search("T"));
    let year = rawDate.slice(0, rawDate.search("-"));
    let dateCut = rawDate.slice(rawDate.search("-")+1);
    let month = dateCut.slice(0, dateCut.search("-"));
    let day = dateCut.slice(dateCut.search("-")+1);

    month = months[month];

    return day + " " + month + " " + year;
}

function dateFormat(date) {
    let today = new Date();

    let timeHours = today.getUTCHours();
    let timeMinutes = today.getUTCMinutes();
    let timeSeconds = today.getUTCSeconds();

    let articleTime = date.slice(date.search("T")+1, date.search("Z"));
    let articleHours = articleTime.slice(0, articleTime.search(":"));
    let articleTimeCut = articleTime.slice(articleTime.search(":")+1);
    let articleMinutes = articleTimeCut.slice(0, articleTimeCut.search(":"));
    let articleSeconds = articleTimeCut.slice(articleTimeCut.search(":")+1);

    if(timeHours < articleHours) {
        timeHours = timeHours+24;
    }

    if(timeHours-articleHours > 0) {
        return `${timeHours-articleHours}h ago`;
    }
    else if(timeMinutes-articleMinutes > 0) {
        return `${timeMinutes-articleMinutes}m ago`;
    }
    else if(timeSeconds-articleSeconds > 0){
        return `${timeSeconds-articleSeconds}s ago`;
    }
}

function isSectionOrUrl(path) {
    return ( 
        path === "home" || 
        path === "world" || 
        path === "politics" || 
        path === "business" || 
        path === "technology" || 
        path === "sport" || 
        path === "sports"
    );
}

function isSearch(path) {
    return (
        path.slice(0, path.search("-")) === "search"
    );
}

app.get('/:path', (req, res) => {

    const path = req.params.path.replace(/\~/g, "/");
    const source = path.slice(0, path.search("-"));
    let section = '';

    let home_url = '';
    let url = '';
    let default_img = '';

    let obj = [];

    section = path.slice(9);

    home_url = "https://content.guardianapis.com/search?orderby=newest&show-fields=starRating,headline,thumbnail,short-url&api-key=591a92b9-9797-407f-96ee-41cd7dbb3532";
    
    url = section.slice(0, section.search("-"))  === "search" ? 
    "https://content.guardianapis.com/search?q="+section.slice(section.search("-")+1)+"&api-key=591a92b9-9797-407f-96ee-41cd7dbb3532&show-blocks=all" :
    "https://content.guardianapis.com/"+section+"?api-key=591a92b9-9797-407f-96ee-41cd7dbb3532&show-blocks=all";
    default_img = "https://assets.guim.co.uk/images/eada8aa27c12fe2d5afa3a89d3fbae0d/fallback-logo.png";

    if(section === "home") {
        fetch(home_url)
        .then(result => result.json())
        .then(data => { data.response.results
        .map((article, index) => {
            obj[index] = 
            {
                key: `${index}`, 
                id: `${article.id}`,
                img: `${article.fields.thumbnail}`,
                title: `${article.webTitle}`,
                date: `${dateFormat(article.webPublicationDate)}`,
                section: `${article.sectionName}`,
                url: `${article.webUrl}`
            }})
            return obj;
        })
        .then(articles => res.json(articles));
    }

    if(section !== "home") {
        if(!isSectionOrUrl(section)) {
            fetch(url)
            .then(result => result.json())
            .then(data => { 
                obj = 
                {
                    id: `${data.response.content.id}`,
                    img: (data.response.content.blocks.main.elements[0].assets.length !== 0) ? 
                    `${data.response.content.blocks.main.elements[0].assets[data.response.content.blocks.main.elements[0].assets.length-1].file}`
                    : "undefined",
                    title: `${data.response.content.webTitle}`,
                    description: `${data.response.content.blocks.body[0].bodyTextSummary}`,
                    date: `${getDate(data.response.content.webPublicationDate)}`,
                    section: `${data.response.content.sectionId}`,
                    url: `${data.response.content.webUrl}`
                }
                return obj;
            })
            .then(articles => res.json(articles));
        }

    }
});

app.listen(port, () => console.log(`Server started on port ${port}`));
