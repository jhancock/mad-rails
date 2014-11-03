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

// books_offline_history is storing the book_id attribute as a String.  This is inconsistent with how Bookmarks store book_id as ObjectId
// should be deleted and not imported, so nothign to do here
