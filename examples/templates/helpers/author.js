module.exports = function(authors, authorName) {
	var author = authors[authorName + '.json'];
	if (author) {
		return author.metadata.name;
	} else {
		return authorName;
	}
}
