db.runCommand(
   { aggregate: "bookmarks",
     pipeline: [
              { $group: {
                _id: { user_id: "$user_id", book_id: "$book_id" },
                uniqueIds: { $addToSet: "$_id" },
                count: { $sum: 1 }
              }},
              { $match: {
                count: { $gt: 1 }
              }},
	      { $out: "dup_bookmarks" }
               ],
      allowDiskUse: true
   }
)
