import 'package:realm/realm.dart';

import '../../features/notes/data/models/note_model.dart';

// Initialize Realm Configuration
final config = Configuration.local([Note.schema]);
final realm = Realm(config);


// realm 99% doesnt need async , 1m object 
// optimized C binaries 