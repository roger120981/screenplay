import React from "react";
import { Button } from "react-bootstrap";
import {
  ListCheck,
  XCircleFill,
  EyeFill,
  EyeSlashFill,
  Icon,
} from "react-bootstrap-icons";
import { Place } from "../../models/place";

interface Props {
  places: Place[];
  hasScreenlessPlaces: boolean;
  showScreenlessPlaces: boolean;
  onClickResetFilters: () => void;
  onClickToggleScreenlessPlaces: () => void;
}

const getPlaceCount = (places: Place[]) => {
  return places.length;
};

const getScreenCount = (places: Place[]) => {
  // Get all screens within the filtered places.
  // TODO: Should we also limit the count to only include screens of the filtered screen type, when that filter is selected?
  const screenIDs = places
    .flatMap((place) => place.screens)
    .map((screen) => screen.id);

  // Remove duplicates by dropping the array into a Set.
  // (Duplicates can occur because certain screens can be registered under multiple places)
  return new Set(screenIDs).size;
};

const PlacesActionBar: React.ComponentType<Props> = ({
  places,
  onClickResetFilters,
  hasScreenlessPlaces,
  showScreenlessPlaces,
  onClickToggleScreenlessPlaces,
}) => {
  return (
    <div className="places-action-bar">
      <ActionBarStats
        placeCount={getPlaceCount(places)}
        screenCount={getScreenCount(places)}
      />
      <span className="places-action-bar__buttons-container">
        {hasScreenlessPlaces && (
          <ActionBarButton
            onClick={onClickToggleScreenlessPlaces}
            IconComponent={showScreenlessPlaces ? EyeFill : EyeSlashFill}
          >
            Screenless places
          </ActionBarButton>
        )}
        <ActionBarButton disabled IconComponent={ListCheck}>
          Bulk edit
        </ActionBarButton>
        <ActionBarButton
          onClick={onClickResetFilters}
          IconComponent={XCircleFill}
        >
          Reset filters
        </ActionBarButton>
      </span>
    </div>
  );
};

interface StatsProps {
  placeCount: number;
  screenCount: number;
}

const ActionBarStats: React.ComponentType<StatsProps> = ({
  placeCount,
  screenCount,
}) => {
  return (
    <span className="places-action-bar__stats">
      <span className="places-action-bar__stats__number">{placeCount}</span>{" "}
      stations ·{" "}
      <span className="places-action-bar__stats__number">{screenCount}</span>{" "}
      screens
    </span>
  );
};

interface ButtonProps {
  disabled?: boolean;
  onClick?: () => void;
  IconComponent?: Icon;
}

const noop = () => {};

const sharedIconProps = {
  size: 16,
  className: "m-0",
  color: "white",
};

const ActionBarButton: React.ComponentType<ButtonProps> = ({
  disabled = false,
  onClick = noop,
  IconComponent,
  children,
}) => {
  return (
    <Button
      className="places-action-bar__button"
      disabled={disabled}
      onClick={onClick}
    >
      {IconComponent && (
        <div className="places-action-bar__button__icon-container">
          <IconComponent {...sharedIconProps} />
        </div>
      )}
      <div className="places-action-bar__button__text">{children}</div>
    </Button>
  );
};

export default PlacesActionBar;
