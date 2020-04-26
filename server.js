const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');
const app = express();

app.use(cors());

const port = process.env.PORT || 5000;

function isvalid(value) {
    return (value !== null && value !== '' && value !== undefined);
}

function dateFormat(date) {
    return date.slice(0, date.search("T"));
}

function getImage(multimedia) {
    for(const image in multimedia) {
        if(multimedia[image].width >= 2000) {
            return multimedia[image].url;
        }
    }
    return "none";
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
                date: `${article.webPublicationDate}`,
                section: `${article.sectionName}`,
                url: `${article.webUrl}`
            }})
            return obj;
        })
        .then(articles => res.json(articles));
    }
});

app.listen(port, () => console.log(`Server started on port ${port}`));
