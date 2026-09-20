← [Back to overview](index.md)

# Tools — Description

## Purpose

The generic modules (`generic.EmberCore.*`) provide tools around the media library. They are enabled via the module settings and integrate through menu and context-menu entries as well as their own dialogs.

## Bulk Renamer

*Bulk Renamer* renames movie and TV show files/folders using freely definable patterns — in batches (*Bulk Rename*, *TV Bulk Renamer*) or individually (*Manual Rename*). The pattern syntax covers placeholders for title, year, resolution, codecs, season/episode numbers and more. Options like *Display Only Movies That Will Be Renamed* and *Automatically Rename Files During Multi-/Single-Scraper* control preview and automation. Failed renames (locked files/folders) are reported with an error message.

## Movie List Exporter

*Export Movies* / *Movie List Exporter* exports the movie library via template files (e.g. HTML lists). *Export Movie List* selects template and target; the templates live in the module's `Templates` folder.

## Media File Manager

File operations for media files: copy/move to target directories (*Copy Files* dialog), optionally via TeraCopy.

## Tag Manager

Management of tags/keywords: create, edit, delete tags and assign them to media items. Additionally, the main application's simple *Tag Manager* dialog exists for direct assignment.

## Media List Editor (Filter Editor)

Edit custom filters and media lists — maintain criteria for the list views which then appear in the filter bar.

## Mapping Editor

Edits the application's mapping lists: genre mapping, regex mapping and simple mapping (e.g. translating genre identifiers or source identifiers into custom values).

## Metadata Editor

Maintains the identifier tables for codecs and metadata (e.g. which codec strings map to which flag/display value).

## Context Menu

Provides additional context-menu entries in the media lists.

## Video Source Mapping

Maps video source identifiers (e.g. which filename parts are recognized as Blu-ray, DVD, HDTV).

## Limitations

- All tools operate on the Ember database — files that have not been scanned yet are not available.
- The Bulk Renamer modifies files and folders on disk; locked or open files cause error messages (*Unable to Rename*).
- Some modules report *Setup Needs Restart* after settings changes.
