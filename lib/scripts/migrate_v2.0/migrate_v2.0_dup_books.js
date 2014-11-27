db.runCommand(
   { aggregate: "books",
     pipeline: [
              { $group: {
                _id: { author: "$author", title: "$title" },
                uniqueIds: { $addToSet: "$_id" },
                count: { $sum: 1 }
              }},
              { $match: {
                count: { $gt: 1 }
              }},
	      { $out: "dup_books" }
               ],
      allowDiskUse: true
   }
)
