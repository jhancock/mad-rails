db.runCommand(
   { aggregate: "users",
     pipeline: [
              { $group: {
                _id: { email: "$email"},
                uniqueIds: { $addToSet: "$_id" },
                count: { $sum: 1 }
              }},
              { $match: {
                count: { $gt: 1 }
              }},
	      { $out: "dup_users" }
               ],
      allowDiskUse: true
   }
)
