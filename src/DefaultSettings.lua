export type Rig = "R6" | "R15" | "BOTH"
export type Settings = {
	UnlockDescendants: boolean,
	MoveToCamera: boolean,
	ParentToSelection: boolean,
	Rig: Rig
}

return {
	UnlockDescendants = true,
	MoveToCamera = false,
	ParentToSelection = true,
	Rig = "R15"
} :: Settings