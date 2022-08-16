class_name PlayerInfo

var session_id: String
var peer_id: int
var username: String


func create(_session_id: String, _username: String, _peer_id: int) -> PlayerInfo:
	session_id = _session_id
	username = _username
	peer_id = _peer_id
	return self


func from_presence(presence: NakamaRTAPI.UserPresence, _peer_id: int) -> PlayerInfo:
	return create(presence.session_id, presence.username, _peer_id)


func from_dict(data: Dictionary) -> PlayerInfo:
	return create(data["session_id"], data["username"], int(data["peer_id"]))


func to_dict() -> Dictionary:
	return {
		session_id = session_id,
		username = username,
		peer_id = peer_id,
	}
