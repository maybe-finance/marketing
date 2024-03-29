import React from "react";

export default function Rate(): JSX.Element {
  return (
    <div className="flex items-center justify-center w-full h-full">
      <svg
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M3.56 12.86C3.36219 13.0518 3.04781 13.0518 2.85 12.86L2.15 12.15C2.05534 12.0561 2.0021 11.9283 2.0021 11.795C2.0021 11.6617 2.05534 11.5339 2.15 11.44L7.32 6.28L5.9 4.85C5.75994 4.70715 5.71851 4.49456 5.79468 4.30958C5.87086 4.12459 6.04996 4.00281 6.25 4H10.5C10.7718 4.01027 10.9897 4.22822 11 4.5V8.75C11.0012 8.95185 10.8809 9.13462 10.695 9.21335C10.5091 9.29207 10.2942 9.2513 10.15 9.11L8.73 7.69L3.56 12.86ZM21.5 8C21.7761 8 22 7.77614 22 7.5V6.5C22 6.22386 21.7761 6 21.5 6H18C17.4477 6 17 6.44772 17 7V10H14C13.4477 10 13 10.4477 13 11V14H10C9.44772 14 9 14.4477 9 15V18H2.5C2.22386 18 2 18.2239 2 18.5V19.5C2 19.7761 2.22386 20 2.5 20H10C10.5523 20 11 19.5523 11 19V16H14C14.5523 16 15 15.5523 15 15V12H18C18.5523 12 19 11.5523 19 11V8H21.5Z"
          className="fill-current"
        />
      </svg>
    </div>
  );
}
