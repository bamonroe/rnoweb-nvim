# Workspace Instructions for Claude

Instructions for Claude Code sessions in this workspace.

## Project Goal

The project goal is described in the `README.md` file


## Git

Maintaining a healthy git repo is of very high importance for this project.

There is a master branch which is assumed to hold always working code.

From the master branch new features will be added by first checking out a
feature branch.

If while developing a feature, there are new ideas about how to complete the
feature, create a "sub feature" branch that branches off this feature branch.

Branches should never be deeper than a feature and sub-feature branch.

Commits to the sub-feature branches should be made extremely atomically with
the idea that they may be discarded or rolled back.

The git history unique to the sub-feature branch should be squashed before being
merged into the feature branch.

The feature branch should also have atomic commits, but if there are many steps
to be undertaken, this is when a sub-feature should be branched.

The feature branch should have its git commit history reduced but not fully
squashed before being merged into master.


Before merging the feature branch, ensure documentation about the feature is
written in an appropriate area. This documentation is meant to be for humans,
and also for future Claude sessions to get up to speed.

The final step before merging is to make sure that existing tests pass, or are
rewritten when there are fundamental changes, and that appropriate tests are
written to make sure that the new feature works as intended.

The feature branch is only merged into master when its goal is working
correctly - even if in a limited nature.

*Open sub-feature branches frequently!*

**ALWAYS PROMPT WHEN MERGING ANY BRANCH!**

## TODO Tracking

The file `TODO.md` in the project root tracks project progress and next steps.

At the start of a session, review TODO.md to understand current project state.

When work is completed:
- Move completed items to the "Completed" section with [x] checkmark
- Add new tasks discovered during implementation
- Update "In Progress" section if work spans multiple sessions

When planning new work:
- Check TODO.md for prioritized next steps
- Add new ideas to "Ideas / Future Work" section

Keep TODO.md current so future sessions can quickly understand project status.


