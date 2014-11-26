// rename fields
db.users.update({}, { $rename : { 'registered' : 'registered_at', 'premium' : 'premium_at' } }, { multi: true } );

// change admin time to privileges array
db.users.find({admin : {$exists : true}}).forEach( function(doc) { 
  doc.privileges = ["admin"]
  db.users.save(doc); 
  });

db.users.update({admin : {$exists : true}}, { $unset : { 'admin' : '' } }, { multi: true } );

// pull city out of geo array and unset geo array
db.users.find({geo : {$exists : true}}).forEach( function(doc) { 
  if (doc.geo != null) {
    doc.city = doc.geo[7];
    db.users.save(doc);
  }
  });

db.users.update({geo : {$exists : true}}, { $unset : { 'geo' : '' } }, { multi: true } );

// unset referral_code and referred_by
db.users.update({referral_code : {$exists : true}}, { $unset : { 'referral_code' : '' } }, { multi: true } );
db.users.update({referred_by : {$exists : true}}, { $unset : { 'referred_by' : '' } }, { multi: true } );

// unset password_reset_at and password_reset_code
db.users.update({password_reset_at : {$exists : true}}, { $unset : { 'password_reset_at' : '' } }, { multi: true } );
db.users.update({password_reset_code : {$exists : true}}, { $unset : { 'password_reset_code' : '' } }, { multi: true } );

// unset all User :email_error
db.users.update({email_error : {$exists : true}}, { $unset : { 'email_error' : '' } }, { multi: true } );

// unset Book :offline_at and :offline_reason if :offline_at is null or does not exist
db.books.update({offline_at : null}, { $unset : { 'offline_at' : '', 'offline_reason' : '' }}, { multi: true } );

// unset all Book :tag_names.
db.books.update({tag_names : {$exists : true}}, { $unset : { 'tag_names' : '' } }, { multi: true } );

// ensure all Book :tags are an array.. No nil allowed
db.books.update({tags : null}, { $set : { 'tags' : [] } }, { multi: true } );

// ensure all Book :read_count and :unique_read_count are set to an integer
db.books.update({read_count : null}, { $set : { 'read_count' : 0 } }, { multi: true } );
db.books.update({unique_read_count : null}, { $set : { 'unique_read_count' : 0 } }, { multi: true } );

